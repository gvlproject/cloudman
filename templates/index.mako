<%inherit file="/base_panels.mako"/>
<%def name="main_body()">
<style type="text/css">
td, th {
vertical-align: top;
}
</style>
<div class="body" style="max-width: 720px; margin: 0 auto;">
    <h2>CloudMan Console</h2>
    <div id="storage_warning" style="display:none;" class="warning"><strong>Warning:</strong> You are running out of disk space. <span id="storage_warning_plus" style="display:none;">Use the icon next to the disk status below to increase your disk size.</span></div>
    <%include file="bits/messages.html" />
    <div id="main_text">
        This is CloudMan - an application that allows you to manage this cloud
        cluster and the services provided within. Once the cluster configuration
        has been completed (indicated by a notification popup), you can start
        using the cluster and the services that were started. For more information
        on the system features, see the
        <a href="https://wiki.galaxyproject.org/CloudMan" target="_blank">wiki</a>.
    </div>
    <h3>Cluster controls</h3>
    <div style='position:relative;text-align:center;'>
        <ul style='display:inline;padding:0;'>
            <li style='display:inline;width:150px;'>
                <a id="stop-button" original-title="Shut down..." class="action-button left-button">Shut down...</a>
            </li>
            <!-- <li style='display:inline;width:150px;'>
                <a class="middle-button action-button" original-title="Add worker nodes..." id="scale_up_button">Add worker nodes <img src="/cloud/static/images/downarrow.png"></a>
            </li>
            <li style='display:inline;width:150px;'>
                <a class="middle-button action-button" original-title="Remove worker nodes..." id="scale_down_button">Remove worker nodes <img src="/cloud/static/images/downarrow.png"></a>
            </li> -->
            <li style='display:inline;width:150px;'>
                <a id='dns' href='' original-title="Access Galaxy" class="action-button right-button">Access Galaxy</a>
            </li>
        </ul>

    <div id='cluster_scale_up_popup' class='cluster_scale_popup'>
        <h4>Add worker nodes</h4>
        <form id="add_instances_form" class="generic_form" name="node_management_form" action="${h.url_for(controller='root',action='add_instances')}" method="post">
        <div class="form-row">
            <label>Number of nodes to start:</label>
            <div id="num_nodes" class="form-row-input">
                <input type="text" name="number_nodes" class="LV_field" id="number_nodes" value="1" size="10">
                <div class="LV_msgbox"><span id="number_nodes_vtag"></span></div>
            </div>
            <br/>
            <a href="http://aws.amazon.com/ec2/instance-types/" target="_blank">Type</a>
                of underlying instance(s):
            <div style="color:#9D9E9E">(master instance type: ${master_instance_type})</div>
            <div id="instance_type_choices" class="form-row-input">
                ## Select available instance types based on cloud name
                <%include file="instance_types.mako" />
            </div>
            ## Spot instances work only for the AWS cloud
            %if cloud_type == 'ec2':
                <div class="form-row">
                    <input type="checkbox" id="use_spot" />
                    Use <a href="http://aws.amazon.com/ec2/spot-instances/" target="_blank">
                        Spot instances
                    </a><br/>
                    Your max <a href="http://aws.amazon.com/ec2/spot-instances/#6" targte="_blank">
                        spot price</a>:
                    <input type="text" name="spot_price" id="spot_price" size="5" disabled="disabled" />
                    <div class="LV_msgbox"><span id="spot_price_vtag"></span></div>
                </div>
            %endif
            <div class="form-row">
                <input type="submit" value="Start Additional Nodes" onClick="return add_pending_node()" class="btn btn-default" />
            </div>
        </div>
        </form>
    </div>
    <div id='cluster_scale_down_popup' class='cluster_scale_popup'>
        <h4>Remove worker nodes</h4>
        <form id="remove_instances_form" class="generic_form" name="node_management_form" action="${h.url_for(controller='root',action='remove_instances')}" method="post">
            <div class="form-row">
                <div id="num_nodes" class="form-row-input">
                    <label>Number of nodes to remove:</label><input type="text" name="number_nodes" id="number_nodes" value="0" size="10">
                </div>
                <div id="num_nodes" class="form-row-input">
                    &nbsp;
                </div>
                <div id="force_termination" class="form-row-input">
                    <div>Force Termination of non-idle nodes?</div>
                    <label for="force_termination_yes">Yes</label><input type="radio" name="force_termination" id="force_termination_yes" value="True">
                    <label for="force_termination_no">No</label><input type="radio" name="force_termination" id="force_termination_no" value="False"  checked="True">
                </div>
                <div id="num_nodes" class="form-row-input">
                    &nbsp;
                </div>
                <div class="form-row">
                    <input type="submit" value="Remove Existing Nodes" class="btn btn-default" />
                </div>
            </div>
        </form>
    </div>
</div>
<h3>Cluster status</h3>
<div id="status_container">
    <div id="cluster_view">
        <div id="cluster_view_tooltip" style="text-align: center;"></div>
        <canvas id="cluster_canvas" width="150" height="120"></canvas>
    </div>
    <table cellpadding="0" cellspacing="10" class="status-table">
        %if cluster_name:
            <tr>
                <td><h4>Cluster name: </h4></td>
                <td>
                    <span id="cluster_name">${cluster_name}</span>&nbsp;
                    <span>
                        <a id="share_a_cluster" title="Share this cluster instance">
                            <span class="btn btn-default btn-sm">
                                <i class="fa fa-share-alt-square fa-lg"></i> Share
                            </span>
                        </a>
                    </span>
                </td>
            </tr>
        %endif
        <tr>
            <td><h4>Disk status: </h4></td>
            <td>
                <span id="du-used">0</span> / <span id="du-total">0</span> (<span id="du-pct">0</span>)
                <span id='expand_vol' title="Expand disk size">
                    <span class="btn btn-default btn-sm">
                        <i class="fa fa-plus-square fa-lg"></i> Grow
                    </span>
                </span>
            ##<span id="snap-status"></span><span id="snap-progress"></span>
            </td>
        </tr>
        <tr><td><h4>Worker status: </h4></td><td>
            <b>Requested</b>: <span id="status-total">0</span>
            <b>Available</b>: <span id="status-available">0</span>
            <b>Idle</b>: <span id="status-idle">0</span>
        </td></tr>
        <tr><td><h4>Service status: </h4></td><td>
            Applications <span id="app-status"><i class="fa fa-circle"></i></span>
            Data <span id="data-status"><i class="fa fa-circle"></i></span>
        </td></tr>
##      <tr><td colspan=2>
##      </td></tr>
    </table>
</div>

## ****************************************************************************
## ***************************** Overlays and such ****************************
## ****************************************************************************

<div id="volume_expand_popup" class="box">
   <a class="boxclose"></a>
    <h2>Expand Disk Space</h2>
    <form id="expand_user_data_volume" name="expand_user_data_volume" class="generic_form" action="${h.url_for(controller='root',action='expand_user_data_volume')}" method="post">
        <div class="form-row">
            Through this form you may increase the disk space available to the
            cluster. All of the cluster services (but not the cluster) will be
            stopped until the new disk is ready, at which point they will all
            be automatically restarted. This process may result in Galaxy jobs
            that are currently running to fail. Note that the new disk size must
            be larger than the current disk size.
            <p>
                During this process, a snapshot of your data volume will be
                created, which can optionally be left in your account. If you
                decide to keep the snapshot for reference, you may also provide
                a brief note that will later be visible in the snapshot's
                description.
            </p>
        </div>
        <div id="permanent_storage_size" class="form-row">
            <label for="new_vol_size">
                New disk size (minimum <span id="du-inc">0</span>GB, maximum 16000GB):
            </label>
            <input type="text" name="new_vol_size" id="new_vol_size" value="0" size="5">GB
            <span id="new_col_size_vtag"></span>
        </div>
        <div id="permanent_storage_size" class="form-row">
            <label for="vol_expand_desc">Note (optional):</label>
            <input type="text" name="vol_expand_desc" id="vol_expand_desc" value="" size="44"><br/>
        </div>
        <div class="form-row">
            <input type="checkbox" name="delete_snap" id="delete_snap">
            <label for="delete_snap">
                If checked, the created snapshot will be deleted after the
                resizing process completes.
            </label>
        </div>
        <input type="hidden" name="fs_name" value="galaxy">
        <div style="padding-top: 15px;">
            <input type="submit" value="Increase disk size" class="btn btn-default"/>
        </div>
    </form>
</div>

## Overlay that prevents any future clicking, see CSS
<div id="snapshotoverlay" style="display:none">
    <div id="snapshotoverlay_msg_box" style="display:none"></div>
    ## Allow the overlay to be hidden between UI updates
    <a id="close-snapshotoverlay" href="#">Temporarily hide overlay</a>
</div>
<div id="no_click_clear_overlay" style="display:none"></div>
<div id="snapshot_status_box" class="box">
    <h2>Volume Manipulation In Progress</h2>
    <div class="form-row">
        <p>Creating a snapshot of the cluster's data volume is in progress. All
        of the cluster services have been stopped for the time being and will resume
        automatically upon completion of the process.<br/>This message should go
        away after the process completes but if it does not, try refreshing the
        page then.</p>
    </div>
    <div class="form-row">
        Snapshot status: <span id="snapshot_status" style="font-style: italic;">configuring</span>
        <span id="snapshot_progress">&nbsp;</span>
    </div>
</div>
<div id="reboot_overlay" style="display:none"></div>
<div id="reboot_status_box" class="box">
    <h2>Reboot In Progress</h2>
    <div class="form-row">
        <p>This page should reload automatically when the reboot is complete.
        However, if it does not after approximately 5 minutes, reload it manually.</p>
    </div>
</div>
<div style="clear: both;"></div>
<div class="overlay" id="overlay" style="display:none"></div>
<div class="box" id="power_off">
    <a class="boxclose"></a>
    <h1>Shut down</h1>
    <form id="power_cluster_off_form" class="generic_form" name="power_cluster_form" action="${h.url_for(controller='root',action='kill_all')}" method="post">
        <div class="form-row">
            <h2>Are you sure you want to power off this cluster?</h2>
            <p>
                This action will stop all services on the cluster and terminate
                any worker nodes associated with this cluster.
            </p>
            % if cluster_storage_type != 'transient':
                <p>
                    Unless you choose to have the cluster deleted, all of your
                    data will be saved beyond the life of this instance. Next
                    time you wish to start this same cluster, use the same
                    access credentials and the same cluster name and CloudMan
                    will reactivate your cluster with your data.
                </p>
            %else:
                <p>
                    This cluster is using transient storage and consequently
                    it cannot be saved. Once shut down, all data will be lost.
                </p>
            %endif
            <label for="terminate_master_instance">
                <b>Automatically terminate the master instance?</b>
            </label>
            <div>
                <input type="checkbox" name="terminate_master_instance" id="terminate_master_instance" checked />
                <label for="terminate_master_instance">
                    If checked, this master instance will automatically terminate
                    after all services have been stopped. If not checked, you should
                    maually terminate this instance from the cloud's dashboard after
                    all services here have been shut down.
                </label>
            </div>
            % if cluster_storage_type != 'transient':
                <p></p><b>Also delete this cluster?</b>
                <div>
                    <input type="checkbox" name="delete_cluster" id="delete_cluster" />
                    If checked, this cluster will be deleted. <b>This action is irreversible!</b>
                    All your data will be deleted, including any shared clusters.
                </div>
            %endif
            <div style="padding-top: 20px;">
                <input type="submit" value="Yes, shut down" class="btn btn-default" />
            </div>
        </div>
    </form>
</div>
<div style="clear: both;"></div>
## Autoscaling link
##Autoscaling is <span id='autoscaling_status'>N/A</span>. Turn <a id="toggle_autoscaling_link" style="text-decoration: underline; cursor: pointer;">N/A</a>?
## Autoscaling configuration popup
<div class="box" id="turn_autoscaling_off">
    <a class="boxclose"></a>
    <h2>Autoscaling Configuration</h2>
    <form id="turn_autoscaling_off_form" class="autoscaling_form" name="turn_autoscaling_off_form" action="${h.url_for(controller='root', action='toggle_autoscaling')}" method="post">
        <div class="form-row">
            If autoscaling is turned off, the cluster will remain in it's current state and you will
            be able to manually add or remove nodes.
        </div>
        <div class="form-row">
            <input type="submit" value="Turn autoscaling off" class="btn btn-default"/>
        </div>
    </form>
</div>
<div class="box" id="turn_autoscaling_on" style="position: absolute;">
    <a class="boxclose"></a>
    <h2>Autoscaling Configuration</h2>
    <form id="turn_autoscaling_on_form" class="autoscaling_form" name="turn_autoscaling_on_form" action="${h.url_for(controller='root', action='toggle_autoscaling')}" method="post">
        <div class="form-row">
            <p>Autoscaling attempts to automate the elasticity offered by cloud computing for this
            particular cluster. <b>Once turned on, autoscaling takes over the control over the size
            of your cluster.</b></p>
            <p>
            Autoscaling is simple, just specify the cluster size limits you want to want to work within
            and use your cluster as you normally do.  The cluster will not automatically shrink to less
            than the minimum number of worker nodes you specify and it will never grow larger than the
            maximum number of worker nodes you specify.
            </p>
            <p>
            While respecting the set limits, if there are more jobs than the cluster can comfortably process at
            a given time autoscaling will automatically add compute nodes; if there are cluster nodes
            sitting idle at the end of an hour autoscaling will terminate those nodes reducing the size
            of the cluster and  your cost.
            </p>
            <p>Once turned on, the cluster size limits respected by autoscaling can be adjusted or
            autoscaling can be turned off.</p>
            <div class="form-row">
                <label>Minimum number of worker nodes to maintain:</label>
                <div class="form-row-input">
                    <input type="number" name="as_min" id="as_min" min="0" max="19">
                </div>
                <label>Maximum number of worker nodes to maintain:</label>
                <div class="form-row-input">
                    <input type="number" name="as_max" id="as_max" min="1" max="19">
                </div>
                <label>Type of Nodes(s):</label>
                <div id="instance_type_choices" class="form-row-input">
                    ## Select available instance types based on cloud name
                    <%include file="instance_types.mako" />
                </div>
                <hr/>
                <p><a href="javascript:void(0)" onClick='$("#as-advanced").toggle()'>Advanced options</a></p>
                <div id="as-advanced" style="display: none;">
                    <p>Placeholder values are the defaults.</p>
                    <label>Minimum number of queued jobs before triggering:</label>
                    <div class="form-row-input">
                        <input type="number" name="num_queued_jobs" id="num_queued_jobs" placeholder="2" min="1" max="99">
                    </div>
                    <label>Mean running job runtime before triggering (seconds):</label>
                    <div class="form-row-input">
                        <input type="number" name="mean_runtime_threshold" id="mean_runtime_threshold" placeholder="60" min="1">
                    </div>
                    <label>Number of nodes to add at once:</label>
                    <div class="form-row-input">
                        <input type="number" name="num_instances_to_add" id="num_instances_to_add" placeholder="1" min="1" max="19">
                    </div>
                </div>
                <br/>
            </div>
        </div>
        <div class="form-row">
            <input type="submit" value="Turn autoscaling on" class="btn btn-default" />
        </div>
    </form>
</div>
<div class="box" id="adjust_autoscaling" style="position: absolute;">
    <a class="boxclose" onClick='$("#as-advanced-adj").hide();'></a>
    <h2>Adjust Autoscaling Configuration</h2>
    <form id="adjust_autoscaling_form" class="autoscaling_form" name="adjust_autoscaling_form" action="${h.url_for(controller='root', action='adjust_autoscaling')}" method="post">
        <div class="form-row">
            Adjust the number of instances autoscaling should maintain for this cluster.
            <p>NOTE: <b>If there are no idle nodes to remove</b>, although the maximum
            limit may be higher than the number of available nodes, autoscaling will wait
            until the nodes become idle to terminate them.
            <div class="form-row">
                <label>Minimum number of nodes to maintain:</label>
                <div class="form-row-input">
                    <input type="number" name="as_min_adj" id="as_min_adj" min="0" max="19">
                </div>
                <label>Maximum number of nodes to maintain:</label>
                <div class="form-row-input">
                    <input type="number" name="as_max_adj" id="as_max_adj" min="1" max="19">
                </div>
                <label>Type of Nodes(s):</label>
                <div id="instance_type_choices" class="form-row-input">
                    ## Select available instance types based on cloud name
                    <%include file="instance_types.mako" />
                </div>
                <hr/>
                <p><a href="javascript:void(0)" onClick='adjAdvancedAS()'>Advanced options</a></p>
                <div id="as-advanced-adj" style="display: none;">
                    <p>Shown values are the ones currently used.</p>
                    <label>Minimum number of queued jobs before triggering:</label>
                    <div class="form-row-input">
                        <input type="number" name="num_queued_jobs" id="num_queued_jobs_adj" min="1" max="99">
                    </div>
                    <label>Mean running job runtime before triggering (seconds):</label>
                    <div class="form-row-input">
                        <input type="number" name="mean_runtime_threshold" id="mean_runtime_threshold_adj" min="1">
                    </div>
                    <label>Number of nodes to add at once:</label>
                    <div class="form-row-input">
                        <input type="number" name="num_instances_to_add" id="num_instances_to_add_adj" min="1" max="19">
                    </div>
                </div>
            </div>
        </div>
        <div class="form-row">
            <input type="submit" value="Adjust autoscaling" class="btn btn-default" onClick='$("#as-advanced-adj").hide();'/>
        </div>
    </form>
</div>
<div class="box" id="share_a_cluster_overlay">
    <a class="boxclose"></a>
    <div id="sharing_accordion">
        <h3><a href="#">Currently shared instances</a></h3>
        <div id='shared_instances_list'>
            <p>Retrieving your shared cluster instances...</p>
            <div class="spinner">&nbsp;</div>
        </div>
        <h3><a href="#">Share this instance</a></h3>
        <div><form id="share_a_cluster_form" class="share_a_cluster" name="share_a_cluster_form" action="${h.url_for(controller='root', action='share_a_cluster')}" method="post">
            <div class="form-row">
                <p><b>This form allows you to share this cluster instance, at its current state,
                with others.</b> You can make the instance public or share it with specific
                users by providing their account information below.<br/>
                You may also share the instance with yourself by specifying your own
                credentials, which will have the effect of saving the instance at
                its current state.</p>
                <p><b>While setting up an instance to be shared, all currently running
                cluster services will be stopped.</b> Then, a snapshot of your data
                volume and a folder in your cluster's bucket will be created
                (under 'shared/[current date and time]); this folder will contain
                your cluster's current configuration. The created snapshot
                and the folder will be given READ permissions to the users
                you choose (or make it public). This will enable those users to instantiate
                their own instances of the given cluster instance. This implies that you will
                only be paying for the created snapshot while users deriving a cluster from
                yours will incur costs for running the actual cluster. After the sharing
                process is complete, services on your cluster will automatically resume.</p>
                <div class="form-row">
                    <div id="public_private">
                        <input type="radio" id="public_visibility" name="visibility" value="public" checked="yes">
                            Public
                        </input>
                        <input type="radio" id="shared_visibility" name="visibility" value="shared">
                            Shared
                        </input>
                    </div>
                    <div>
                        <label for="id-share-desc" style="line-height: 25px;">
                            Optional cluster share description (less than 255 characters)
                        <label><br/>
                        <input type="text" id="id-share-desc" name="share_desc" value="" size="100" />
                    </div>
                    <div id="user_permissions" style="display: none;">
                        <div id="add_user">
                            <h4>Specific user permissions:</h4>
                            <p><strong>Both fields must be provided for each of the users.</strong><br/>
                            These numbers can be obtained from the bottom of the
                            AWS Security Credentials page, under <i>Account Identifiers</i> section.</p>
                            <div style="height: 38px;"><span style="display: inline-block; width: 150px;">AWS account numbers:</span>
                                <input type="text" id="user_ids" name="user_ids" size="0" value="" />
                                <span class="share_cluster_help_text">CSV numbers</span>
                            </div>
                            <div style="height: 38px;"><span style="display: inline-block; width: 150px;">AWS canonical user IDs:</span>
                                <input type="text" id="canonical_ids" name="canonical_ids" size="40" value="" />
                                <span class="share_cluster_help_text">CSV HEX numbers</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="form-row">
                <input type="submit" value="Share this instance" class="btn btn-default" />
            </div>
        </form></div>
    </div>
</div>
<div class="box" id="del_scf_popup">
    <h2>Delete shared cluster instance confirmation</h2>
    <div>Are you sure you want to delete shared cluster instance under
    <i><span id="scf_txt">&nbsp;</span></i>
    and the corresponding snapshot with ID <i><span id="scf_snap">&nbsp;</span></i>?<br/>
    <p>This action cannot be undone.</p></div>
    <p><span class="action-button" id="del_scf_conf">Delete this instance</span>&nbsp;
    <span class="action-button" id="del_scf_cancel">Do not delete</span></p>
</div>
<div id="voloverlay" class="overlay" style="display:none"></div>
<div id="popupoverlay" class="overlay" style="display:none"></div>
<div class="box" id="volume_config">
    <h2 style="text-align:center;">Initial CloudMan Platform Configuration</h2>
    <div class="form-row">
        <p style="text-align:justify;">
            Welcome to CloudMan. This application will allow you to manage this
            cluster platform and the services provided within. To get started,
            choose the type of platform you'd like to work with and provide the
            associated value, if any. More information about each of the
            available types can be found
            <a href="https://wiki.galaxyproject.org/CloudMan/ClusterTypes" target="_blank">here</a>.
        </p>
    </div>
    <form id="initial_volume_config_form" name="power_cluster_form" action="${h.url_for(controller='root',action='initialize_cluster')}" method="post">
        <div class="form-row">
            <input id="galaxy-cluster" type="radio" name="startup_opt" value="Galaxy" checked='true' style="float:left">
            <label for="galaxy-cluster">
                <span style="display: block;margin-left: 20px;">
                    <b>Cluster with Galaxy</b>: a preconfigured Galaxy application
                    with numerous bioinformatics tools, many gigabytes of genomic
                    reference datasets, a production-quality database, a fast
                    web server and a cluster job manager.
                    <div style="margin: 12px 0 2px 0;">
                        You have a choice of the type and size of storage to use:
                    </div>
                </span>
            </label>
            <div style="text-align:left;margin-left: 18px">
                %if cloud_type == 'ec2':
                    <input id="id-galaxy-cluster-persistent" type="radio" name="storage_type" value="volume" checked="true">
                %else:
                    <input id="id-galaxy-cluster-persistent" type="radio" name="storage_type" value="volume">
                %endif
                <label for="id-galaxy-cluster-persistent">
                    Persistent volume storage: size
                </label>
                <input id="id-galaxy-cluster-persistent-size" type="text" name="storage_size" class="LV_field" value="" size="5" placeholder="10">GB <span id="g_pss_vtag"></span>
            </div>
            <div style="text-align:left;margin-left: 18px">
                %if cloud_type == 'ec2':
                    <input id="galaxy-transient" type="radio" name="storage_type" value="transient">
                %else:
                    <input id="galaxy-transient" type="radio" name="storage_type" value="transient" checked='true'>
                %endif
                <label for="galaxy-transient">
                    Transient instance storage: ${transient_fs_size} GB
                </label>
            </div>
        </div>

        <div id='extra_startup_options'>
            <div class="form-row">
                <input id="data-cluster" type="radio" name="startup_opt" value="Data" style="float:left">
                <label for="data-cluster">
                    <span style="display: block;margin-left: 20px;">
                        <b>Cluster only</b>: a cluster-in-the-cloud without any
                        applications automatically added.
                        <div style="margin: 12px 0 2px 0;">
                            Choose the type and size of storage you would like
                            for the cluster:
                        </div>
                    </span>
                </label>
                <div style="text-align: left; margin-left: 18px;">
                    <input id="id-data-cluster-persistent" type="radio" name="storage_type" value="volume">
                    <label for="id-data-cluster-persistent">
                        Persistent volume storage: size
                    </label>
                    <input id="id-data-cluster-storage-size" type="text" name="storage_size" class="LV_field" value="" size="5">GB <span id="id-data-cluster-storage-size-vtag"></span>
                </div>
                <div style="text-align: left; margin-left: 18px;">
                    <input id="id-cluster-only-transient" type="radio" name="storage_type" value="transient">
                    <label for="id-cluster-only-transient">
                        Transient instance storage: ${transient_fs_size} GB
                    </label>
                </div>
            </div>

            <div class="form-row">
                <input id="share-cluster" type="radio" name="startup_opt" value="Shared_cluster" style="float:left">
                <label for="share-cluster">
                    <span style="display: block;margin-left: 20px;">
                        <b>Cloned cluster</b>: derive your cluster form someone else's shared cluster. <i>Note</i> that this form field works only
                        for instances that were shared after July 1, 2013! For instances
                        shared before that date, please use <a href="http://usegalaxy.org/cloudlaunch" target="_blank">CloudLaunch<a/>
                        and provide the share string there. <br/>
                        Specify the provided cluster share-string (for example,
                        <span style="white-space:nowrap; font-style: italic;">cm-0011923649e9271f17c4f83ba6846db0/shared/2013-07-01--21-00</span>):
                    </span>
                </label>
                <input style="margin-left:20px"  type="text" name="share_string" class="LV_field" id="id-share-string" value="" size="50">
                    <label for="id-share-string">Cluster share-string</label>
            </div>
        </div>
        <div id="toggle_extra_startup_options_cont" class="form-row">
            <a id='toggle_extra_startup_options' href="#">
                Show additional startup options
            </a>
        </div>
        <br/>
        <div class="form-row" style="text-align:center;">
            <input type="submit" value="Choose configuration option" id="start_cluster_submit_btn" class="btn btn-default" />
        </div>
        </form>
    </div>
</div>
<div id="log_container">
    <div id="log_container_header">
        <h3>Cluster info log <i class="fa fa-chevron-down"></i></h3>
        <div id="log_container_header_img">
            <span id="log-icon-txt">Collapse</span> <i class="fa fa-plus-circle fa-lg"></i>
        </div>
    </div>
    <div id="log_container_body">
    <ul>
    </ul>
    </div>
</div>

## ****************************************************************************
## ******************************** Javascript ********************************
## ****************************************************************************

<script type="text/javascript">
var instances = Array();
var cluster_status = "OFF";
var click_timeout = null;
var use_autoscaling = null;
var as_min = 0; //min number of instances autoscaling should maintain
var as_max = 0; //max number of instances autoscaling should maintain

$(function() {
    $( "#sharing_accordion" ).accordion({
        autoHeight: false,
        navigation: true,
    });
});
</script>

<script type='text/javascript' src="${h.url_for('/static/scripts/jquery.tipsy.js')}"></script>
<script type='text/javascript' src="${h.url_for('/static/scripts/jquery.form.js')}"></script>
<script type='text/javascript' src="${h.url_for('/static/scripts/cluster_canvas.js')}"> </script>
<script type='text/javascript' src="${h.url_for('/static/scripts/jquery.stopwatch.js')}"> </script>
<script type="text/javascript">

function hidebox(){
    $('.box').hide();
    $('.overlay').hide();
    $('.cluster_scale_popup').hide();
    $('.action-button.button-clicked').removeClass('button-clicked');
    $('#popupoverlay').hide();
    $('#volume_expand_popup').hide();
    $('#power_off').hide();
    $('#overlay').hide();
}

function scrollLog(){
    if ($("#log_container_body").attr("scrollHeight") <= ($("#log_container_body").scrollTop() + $("#log_container_body").height() + 100)){
        $('#log_container_body').animate({
            scrollTop: $("#log_container_body").attr("scrollHeight") + 100
        }, 1000);
    }
}

function toggleVolDialog(){
    if ($('#volume_config').is(":visible")){
        $('#volume_config').hide();
        $('#voloverlay').hide();
    }else{
        $('#voloverlay').show();
        $('#volume_config').show();
    }
}

function adjAdvancedAS(){
    if ($("#as-advanced-adj").is(":visible")){
        $("#as-advanced-adj").hide();
    } else {
        $("#as-advanced-adj").show();
        // Fetch current values
        $.getJSON("${h.url_for(controller='root',action='autoscaling_state')}",
            {},
            function(data){
                if (data){
                    $('#num_queued_jobs_adj').val(data.as_num_queued_jobs);
                    $('#mean_runtime_threshold_adj').val(data.as_mean_runtime_threshold);
                    $('#num_instances_to_add_adj').val(data.as_num_instances_to_add);
                }
            }
        );
    }
}

function update_ui(data){
    if (data){
        $('#dns').attr("href", data.dns);
        if (data.dns == '#'){
            $('#dns').addClass('ab_disabled');
            $('#dns').attr("target", '');
            $('#galaxy_log').hide()
        }else{
            $('#dns').removeClass('ab_disabled');
            $('#dns').attr("target", '_blank');
            $('#galaxy_log').show()
        };
        $('#status-idle').text( data.instance_status.idle );
        $('#status-available').text( data.instance_status.available );
        $('#status-total').text( data.instance_status.requested );
        $('#du-total').text(data.disk_usage.total);
        $('#du-inc').text(Math.round(data.disk_usage.total.slice(0,-1)));
        $('#du-used').text(data.disk_usage.used);
        $('#du-pct').text(data.disk_usage.used_percent);
        if($('#new_vol_size').val() == '0'){
            $('#new_vol_size').val(Math.round(data.disk_usage.total.slice(0,-1)));
        }
        if (parseInt(data.disk_usage.used_percent) > 80){
            $('#storage_warning').show();
            if (data.cluster_storage_type != 'transient'){
                $('#storage_warning_plus').show();
            }
        }else{
            $('#storage_warning').hide();
            $('#storage_warning_plus').hide();
        }
        $('#snap-progress').text(data.snapshot.progress);
        $('#snap-status').text(data.snapshot.status);
        // DBTODO write generic services display
        $('#app-status').attr('style', 'color: ' + data.app_status);
        $('#data-status').attr('style', 'color: ' + data.data_status);
        // Show volume manipulating options only after data volumes are ready
        if (data.testflag !== true && (data.cluster_storage_type == 'transient' || data.data_status !== 'green')){
            $('#expand_vol').hide();
            $('#share_a_cluster').hide();
        }else{
            $('#expand_vol').show();
            $('#share_a_cluster').show();
        }
        cluster_status = data.cluster_status;
        if (cluster_status === "SHUTTING_DOWN"){
            shutting_down();
            return true; // Must return here because the remaining code clears the UI
        }
        else if (cluster_status === "TERMINATED"){
            $('.action-button').addClass('ab_disabled');
            $('#snapshotoverlay').show(); // Overlay that prevents any future clicking
            $('#snapshotoverlay_msg_box').html("<div id='snapshotoverlay_msg_box_important'> \
                <h4>Important:</h4><p>This cluster has terminated. If not done automatically, \
                please terminate the master instance from the cloud console.</p></div>");
            $('#snapshotoverlay_msg_box').show();
            return true; // Must return here because the remaining code clears the UI
        }
        if (data.autoscaling.use_autoscaling === true) {
            use_autoscaling = true;
            as_min = data.autoscaling.as_min;
            as_max = data.autoscaling.as_max;
            $('#scale_up_button').addClass('ab_disabled');
            $('#scale_up_button > img').hide();
            $('#scale_down_button').addClass('ab_disabled');
            $('#scale_down_button > img').hide();
        } else if (data.autoscaling.use_autoscaling === false) {
            use_autoscaling = false;
            as_min = 0;
            as_max = 0;
            $('#scale_up_button').removeClass('ab_disabled');
            $('#scale_up_button > img').show();
            if (data.instance_status.requested == '0'){
                $('#scale_down_button').addClass('ab_disabled');
                $('#scale_down_button > img').hide();
            }else{
                $('#scale_down_button').removeClass('ab_disabled');
                $('#scale_down_button > img').show();
            }
        }
        if (data.snapshot.status !== "None"){
            if(!$('#snapshotoverlay').is(':visible')) {
                $('#snapshotoverlay').show();
            }
            $('#snapshot_status_box').show();
            $('#snapshot_status').text(data.snapshot.status);
            if (data.snapshot.progress !== "None"){
                $('#snapshot_progress').html("; progress: <i>"+data.snapshot.progress+"</i>");
            } else {
                $('#snapshot_progress').html("");
            }
        }else{
            $('#snapshot_status_box').hide();
            $('#snapshotoverlay').hide();
        }
    }
}
function update_log(data){
    if (data){
        if(data.log_messages.length > 0){
            var logMsgs = "";
            for (i = 0; i < data.log_messages.length; i++){
                logMsgs += "<li>"+data.log_messages[i]+"</li>";
            }
            $('#log_container_body>ul').html(logMsgs);
            scrollLog();
        }
    }
}

function update(repeat_update){
    $.getJSON("${h.url_for(controller='root',action='full_update')}",
        {},
        function(data){
            if (data){
                update_ui(data.ui_update_data);
                update_log(data.log_update_data);
                update_messages(data.messages);
            }
        });
    if (repeat_update === true){
        window.setTimeout(function(){update(true)}, 5000);
    }
}

function reboot_update(){
    $.ajax({
      url: "${h.url_for(controller='root',action='full_update')}",
      dataType: 'json',
      success: function(data){
                update_ui(data.ui_update_data);
                update_log(data.log_update_data);
                $('#reboot_overlay').hide();
                $('#reboot_status_box').hide();
                },
      error: function(data){window.setTimeout(function(){reboot_update()}, 10000)}
    });
}

function show_confirm(scf, snap_id){
    $('#del_scf_popup').show();
    $('#scf_txt').text(scf);
    $('#scf_snap').text(snap_id);
    // FIXME: Need to have an individual element ID for each of the shared instances
    $('#del_scf_conf').click(function(){
        $.get("${h.url_for(controller='root',action='delete_shared_instance')}",
            {'shared_instance_folder': scf, 'snap_id': snap_id},
            function(){
                $('#del_scf_popup').hide();
                get_shared_instances();
            });
    });
    $('#del_scf_cancel').click(function(){
        $('#del_scf_popup').hide();
    });
}
function get_shared_instances(){
    $.getJSON("${h.url_for(controller='root',action='get_shared_instances')}",
        {},
        function(data){
            if(data){
                var shared_list = $('#shared_instances_list').html(
                    "<p>These are the shared versions of this cluster that " +
                    "you can share with others so they can create clones of your " +
                    "cluster. Simply copy the Share string ID and send it or " +
                    "publish it. For more information about cluster sharing, " +
                    "see <a href='https://wiki.galaxyproject.org/CloudMan/Sharing'" +
                    "target='_blank'>this page</a>. " +
                    "Before others can create the clones, the share " +
                    "<i>Status</i> must reach 100% (note that depending on the " +
                    "size of your disk, this may take many hours). </p>" +
                    "<p><b>Note</b> that if you delete a share, any instances " +
                    "that other users have been created (and used) will no " +
                    "longer be functional!</p>");
                var table = $("<table/>");
                if (data.shared_instances.length > 0) {
                    table.addClass("shared_instances_table");
                    tr = $('<tr/>');
                    tr.append($('<th/>').text("Visibility"));
                    tr.append($('<th/>').text("Share string ID and share description"));
                    tr.append($('<th/>').text("Status"));
                    tr.append($('<th/>').text("Snapshot ID"));
                    tr.append($('<th/>').text("Delete?"));
                    table.append(tr);
                    for (n=0; n<(data.shared_instances).length; n++) {
                        var fn = function(i) {
                            var tr = $("<tr class='shared-instance-ttr' />");
                            tr.append($('<td/>').text(data.shared_instances[i].visibility));
                            tr.append($('<td/>').text(data.shared_instances[i].bucket));
                            tr.append($('<td/>').text(data.shared_instances[i].snap_progress));
                            tr.append($('<td/>').text(data.shared_instances[i].snap));
                            anchor = $("<a>&nbsp;</a>").click(function () {
                                show_confirm(data.shared_instances[i].bucket, data.shared_instances[i].snap);
                            }).addClass("del_scf");
                            tr.append($('<td style="padding-left: 15px;" />').html(anchor));
                            table.append(tr);
                            var tr2 = $('<tr/>');
                            tr2.append($('<th/>'));
                            tr2.append($('<td colspan="4" class="shared-instance-desc" />').text(data.shared_instances[i].snap_desc));
                            table.append(tr2);
                        };
                        fn(n);
                    }
                    shared_list.append(table);
                } else {
                    shared_list.text("You have no shared cluster instances.");
                }
            }
        });
}

function show_log_container_body() {
    $('#log_container_header_img i').removeClass('fa-plus-circle');
    $('#log_container_header_img i').addClass('fa-minus-circle');
    $('#log_container_header_img span').text('Collapse');
    $('#log_container_header').addClass('clicked');
    $('#log_container_body').slideDown('fast');
}

function hide_log_container_body() {
    $('#log_container_header_img i').addClass('fa-plus-circle');
    $('#log_container_header_img i').removeClass('fa-minus-circle');
    $('#log_container_header_img span').text('Expand');
    $('#log_container_body').slideUp('fast', function(){
        $('#log_container_header').removeClass('clicked');
    });
}

// This is called when worker nodes are added by the user.
// Causes a pending instance to be drawn
function add_pending_node() {
    inst_kind = 'on-demand';
    if ($('#use_spot').length != 0 && $('#use_spot').attr("checked") == 'checked') {
        inst_kind = 'spot';
    } increment_pending_instance_count(parseInt(document.getElementById("add_instances_form").elements["number_nodes"].value), inst_kind);
        return true;
}

function shutting_down() {
    // Do the UI updates to indicate the cluster is in the 'SHUTTING_DOWN' state
    $('#snapshotoverlay_msg_box').html("<div id='snapshotoverlay_msg_box_warning'> \
        <h4>Important:</h4><p>This cluster is terminating. Please wait for all the services \
        to stop and for all the nodes to be removed. Then, if not done automatically, \
        terminate the master instance from the cloud console. All of the buttons on the \
        console have been disabled at this point.</p></div>");
    $('#snapshotoverlay_msg_box').show();
    $('.action-button').addClass('ab_disabled');
    // Show and scroll the log
    show_log_container_body();
    update_log();
    $('#log_container_body').animate({
        scrollTop: $("#log_container_body").attr("scrollHeight") + 100
    }, 1000);
    $('#snapshotoverlay').show(); // Overlay that prevents any future clicking
}

$(document).ready(function() {
    var initial_cluster_type = '${initial_cluster_type}';
    var permanent_storage_size = ${permanent_storage_size};

    $('.instance_type').change(function(){
        if ($(this).val() == 'custom_instance_type') {
            $(this).next('#cit_container').show();
            $('#custom_instance_type').focus();
        } else {
            $(this).next('#cit_container').hide();
        }
    });

    $('#shared_visibility').click(function() {
        $('#user_permissions').show();
        $('#user_ids').val("");
        $('#canonical_ids').val("");
    });
    $('#public_visibility').click(function() {$('#user_permissions').hide();});

    $('#stop-button').click(function(){
        if ($(this).hasClass('ab_disabled')){
            return;
        }else{
            $('#overlay').show();
            $('#power_off').show();
        }
    });
    $('#scale_up_button').click(function(){
        if ($(this).hasClass('ab_disabled')){
            return;
        }else{
            $('.cluster_scale_popup').hide();
            $('.action-button.button-clicked').removeClass('button-clicked');
            $('#popupoverlay').show();
            $('#scale_up_button').addClass('button-clicked');
            $('#cluster_scale_up_popup').show();
        }
    });
    $('#scale_down_button').click(function(){
        if ($(this).hasClass('ab_disabled')){
            return;
        }else{
            $('.cluster_scale_popup').hide();
            $('.action-button.button-clicked').removeClass('button-clicked');
            if (instances.length > 0) {
                $('#scale_down_button').addClass('button-clicked');
                $('#popupoverlay').show();
                $('#cluster_scale_down_popup').show();
            }
        }
    });
    $('#share_a_cluster').click(function(){
        if ($(this).hasClass('ab_disabled')){
            return;
        }else{
            $('#overlay').show();
            $('#share_a_cluster_overlay').show();
            get_shared_instances();
        }
    });
    $('#expand_vol').click(function(){
        $('#overlay').show();
        $('#volume_expand_popup').show();
    });
    $('#overlay').click(function(){
        hidebox();
    });
    $('#toggle_extra_startup_options').click(function(){
        // $('#toggle_extra_startup_options_cont').hide();
        // $('#extra_startup_options').show();
        if ($('#extra_startup_options').is(":visible")){
            $('#extra_startup_options').hide();
            $('#toggle_extra_startup_options').text('Show additional startup options');
        }else{
            $('#extra_startup_options').show();
            $('#toggle_extra_startup_options').text("Hide additional startup options");
        }
    });
    $('#popupoverlay').click(function(){
        $('.cluster_scale_popup').hide();
        $('#volume_expand_popup').hide();
        $('.action-button.button-clicked').removeClass('button-clicked');
        $('#popupoverlay').hide();
    });
    $('.boxclose').click(function(){
        hidebox();
    });
    $('#log_container_header').click(function() {
        if ($('#log_container_body').is(":hidden")){
            show_log_container_body();
        } else {
            hide_log_container_body();
        }
        return false;
    });
    show_log_container_body();

    $('.generic_form').ajaxForm({
        type: 'POST',
        dataType: 'json',
        beforeSubmit: function(data){
            hidebox();
        },
        success: function( data ) {
            update_ui(data);
        }
    });

    $('.autoscaling_form').ajaxForm( {
        type: 'POST',
        dataType: 'json',
        beforeSubmit: function(data){
            hidebox();
        },
        success: function( data ) {
            if (data){
                use_autoscaling = data.running;
                as_min = data.as_min;
                as_max = data.as_max;
                update_ui(data.ui_update_data);
            }
            refreshTip();
        }
    });

    $('#share_a_cluster_form').ajaxForm({
        type: 'POST',
        dataType: 'json',
        beforeSubmit: function(data){
            hidebox();
            $('#snapshotoverlay').show();
            $('#snapshot_status_box').show();
        },
        success: function(data) {
            $('#snapshot_status_box').hide();
            $('#overlay').show();
            $('#share_a_cluster_overlay').show();
            get_shared_instances();
        }
    });

    $('#initial_volume_config_form').ajaxForm( {
        type: 'POST',
        dataType: 'json',
        beforeSubmit: function(){
            cluster_status = "STARTING";
            toggleVolDialog();
        },
        success: function(data) {
            update_ui(data);
        }
    });

    $('#power_cluster_off_form').ajaxForm( {
        type: 'POST',
        dataType: 'json',
        beforeSubmit: function(data){
            shutting_down();
            hidebox();
        },
        success: function( data ) {
            update_ui(data);
        }
    });

    $('#update_reboot_now').click(function(){
        $('#reboot_overlay').show();
        $('#reboot_status_box').show();
        $.getJSON("${h.url_for(controller='root',action='reboot')}",
            function(data){
                if (data.rebooting === true){
                    window.setTimeout(function(){reboot_update()}, 10000);
                }else{
                    update(false);
                }
            });
    });

    $('#update_cm').click(function(){
        $.getJSON("${h.url_for(controller='root',action='update_users_CM')}",
            function(data){
                if (data.updated === true){
                    $('#cm_update_message').html('<span style="color:#5CBBFF">Update Successful</span>, CloudMan update will be applied on cluster restart.&nbsp;&nbsp;&nbsp;');
                    $('#update_reboot_now').show();
                }else{
                    $('#cm_update_message').html('There was an error updating CloudMan.&nbsp;&nbsp;&nbsp;');
                }
            });
    });
    // Toggle accessibility of spot price field depending on whether spot instances should be used
    $("#use_spot").click(function() {
        if ($("#use_spot").attr("checked") == 'checked') {
            $("#spot_price").removeAttr('disabled');
            $("#spot_price").focus();
        } else {
            $("#spot_price").attr('disabled', 'disabled');
            $("#spot_price").val("");
        }
    });
    // Form validation
    var number_nodes = new LiveValidation('number_nodes', { validMessage: "OK", wait: 300, insertAfterWhatNode: 'number_nodes_vtag' } );
    number_nodes.add( Validate.Numericality, { minimum: 1, onlyInteger: true } );
    if (permanent_storage_size === 0) {
        var g_permanent_storage_size = new LiveValidation('id-galaxy-cluster-persistent-size', { validMessage: "OK", wait: 300, insertAfterWhatNode: 'g_pss_vtag' } );
        var d_permanent_storage_size = new LiveValidation('id-data-cluster-storage-size', { validMessage: "OK", wait: 300, insertAfterWhatNode: 'id-data-cluster-storage-size-vtag' } );

        ## Set maximum size only for ec2, since openstack supports volumes larger than 1TB
        %if cloud_type == 'ec2':
        	g_permanent_storage_size.add( Validate.Numericality, { minimum: ${default_data_size}, maximum: 16000, onlyInteger: true } );
        	d_permanent_storage_size.add( Validate.Numericality, { minimum: 1, maximum: 16000, onlyInteger: true } );
        %else:
        	g_permanent_storage_size.add( Validate.Numericality, { minimum: ${default_data_size}, onlyInteger: true } );
        	d_permanent_storage_size.add( Validate.Numericality, { minimum: 1, onlyInteger: true } );
        %endif
    }
    if ($('#spot_price').length != 0) {
        // Add LiveValidation only if the field is actually present on the page
        var spot_price = new LiveValidation('spot_price', { validMessage: "OK", wait: 300, insertAfterWhatNode: 'spot_price_vtag' } );
        spot_price.add( Validate.Numericality, { minimum: 0 } );
    }
    var expanded_storage_size = new LiveValidation('new_vol_size', { validMessage: "OK", wait: 300, insertAfterWhatNode: 'new_col_size_vtag' } );
    expanded_storage_size.add( Validate.Numericality, { minimum: 1, maximum: 16000 } );

    if (initial_cluster_type === 'None') {
        toggleVolDialog();
    }
    // Add tooltips
    $('#share_a_cluster').tipsy({gravity: 'w', fade: true});
    $('#expand_vol').tipsy({gravity: 'w', fade: true});

    // Enable onclick events for the option in the initial cluster configuration box
    $('#galaxy-cluster').click(function() {
        $('#id-galaxy-cluster-persistent').attr('checked', 'checked');
    });
    $('#id-galaxy-cluster-persistent').click(function() {
        $('#id-galaxy-cluster-persistent-size').focus();
    });
    $('#id-galaxy-cluster-persistent-size').focus(function() {
        $('#galaxy-cluster').attr('checked', 'checked');
        $('#id-galaxy-cluster-persistent').attr('checked', 'checked');
    });
    $('#galaxy-transient').click(function() {
        $('#galaxy-cluster').attr('checked', 'checked');
    });

    $('#data-cluster').click(function() {
        $('#id-cluster-only-transient').attr('checked', 'checked');
    });
    $('#id-data-cluster-persistent').click(function() {
        $('#data-cluster').attr('checked', 'checked');
        $('#id-data-cluster-storage-size').focus();
    });
    $('#id-data-cluster-storage-size').focus(function() {
        $('#data-cluster').attr('checked', 'checked');
        $('#id-data-cluster-persistent').attr('checked', 'checked');
    });
    $('#id-cluster-only-transient').click(function() {
        $('#data-cluster').attr('checked', 'checked');
    });

    $('#share-cluster').click(function() {
        $('#id-share-string').focus();
        $('#id-galaxy-cluster-persistent').attr('checked', false);
    });
    $('#id-share-string').focus(function() {
        $('#share-cluster').attr('checked', 'checked');
        $('#id-galaxy-cluster-persistent').attr('checked', false);
    });
    $('#close-snapshotoverlay').click(function(){
        $('#snapshotoverlay').hide();
        hidebox();
    });

    // Initiate the update calls
    update(true);
});

</script>
    </div>
</%def>
